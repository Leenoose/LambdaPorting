using Microsoft.AspNetCore.Mvc;

namespace cmw_dashboard.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class IndexController : ControllerBase
    {
        [HttpGet]
        public string Index()
        {
            return "Hello World! 11:04:00 AM!";
        }
    }
}
