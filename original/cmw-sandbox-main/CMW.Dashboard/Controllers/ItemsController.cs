using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.AspNetCoreServer;
using Amazon.Lambda.Core;
using Microsoft.AspNetCore.Mvc;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace CMW.Dashboard.Controllers
{
    [Route("v{version:apiVersion}/[controller]")]
    [ApiController]
    [ApiVersion("1.0")]
    public class ItemsController : ControllerBase
    {

        private static List<Item> items = new List<Item>
        {
            new() { Id = 1, Name = "Item 1", Description = "Description 1" },
            new() { Id = 2, Name = "Item 2", Description = "Description 2" },
        };

        // GET: api/<ItemsController>
        [HttpGet]
        public IEnumerable<Item> Get()
        {
            return items;
        }


        // GET api/<ItemsController>/5
        [HttpGet("{id}")]
        public ActionResult<Item> Get(int id)
        {
            var item = items.FirstOrDefault(i => i.Id == id);
            if (item == null)
                return NotFound();

            return item;
        }

        // POST api/<ItemsController>
        [HttpPost]
        public ActionResult<Item> Post(Item item)
        {
            if (items.Any(i => i.Id == item.Id))
                return BadRequest("Item with the same ID already exists.");

            items.Add(item);
            return CreatedAtAction(nameof(Get), new { id = item.Id }, item);
        }

        // PUT api/<ItemsController>/5
        [HttpPut("{id}")]
        public IActionResult Put(int id, Item item)
        {
            var index = items.FindIndex(i => i.Id == id);
            if (index < 0)
                return NotFound();

            items[index] = item;
            return NoContent();
        }


        // DELETE api/<ItemsController>/5
        [HttpDelete("{id}")]
        public IActionResult Delete(int id)
        {
            var index = items.FindIndex(i => i.Id == id);
            if (index < 0)
                return NotFound();

            items.RemoveAt(index);
            return NoContent();
        }

        [HttpGet("getip")]
        public Dictionary<string, List<string>> GetIp()
        {
           
            try
            {
                var ips = new Dictionary<string, List<string>>();

                HttpContext.Items.TryGetValue(AbstractAspNetCoreFunction.LAMBDA_REQUEST_OBJECT, out var lambdaRequestObj);

                if (lambdaRequestObj is APIGatewayProxyRequest request)
                {
                    ips.Add("Lambda source Ip", new() { request.RequestContext.Identity.SourceIp });
                }

                HttpContext.Request.Headers.TryGetValue("X-Forwarded-For", out var forwardedIps);

                ips.Add("x-forwarded-for", forwardedIps.ToList());

                HttpContext.Request.Headers.TryGetValue("X-Real-Ip", out var realIp);

                ips.Add("x-real-ip", realIp.ToList());

                ips.Add("httpcontext.remoteipaddress", new() { HttpContext.Connection.RemoteIpAddress?.ToString() ?? "" });

                return ips;
            }
            catch (Exception ex)
            {
                LambdaLogger.Log(ex.Message);
            }

            return new();
        }
    }

    public  class Item
    {
        public int Id { get; set; }
        public string Name { get; set; } = "";
        public string Description { get; set; } = "";
    }
}
