using Microsoft.AspNetCore.Mvc;


namespace CMW.Dashboard.Controllers
{
    [Route("v{version:apiVersion}/[controller]")]
    [ApiController]
    [ApiVersion("1.0")]
    public class IndexController : ControllerBase
    {
        [HttpGet]
        [MapToApiVersion("1.0")]
        public string Index()
        {
            return "Hello World! 11:04:00 AM!";
        }
    }
}
