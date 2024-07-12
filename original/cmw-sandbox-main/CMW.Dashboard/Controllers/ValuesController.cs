using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.AspNetCoreServer;
using Microsoft.AspNetCore.Mvc;

namespace CMW.Dashboard.Controllers;

[Route("api/[controller]")]
public class ValuesController : ControllerBase
{
    // GET api/values

    [HttpGet]
    public Dictionary<string, List<string>> GetIp()
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

    // GET api/values/5
    [HttpGet("{id}")]
    public string Get(int id)
    {
        return "value";
    }

    // POST api/values
    [HttpPost]
    public void Post([FromBody]string value)
    {
    }

    // PUT api/values/5
    [HttpPut("{id}")]
    public void Put(int id, [FromBody]string value)
    {
    }

    // DELETE api/values/5
    [HttpDelete("{id}")]
    public void Delete(int id)
    {
    }
}