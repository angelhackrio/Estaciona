using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Threading.Tasks;
using ParkAndGoBackend.Models;
using System.Web.Http.Description;

namespace ParkAndGoBackend.Controllers
{
    /// <summary>
    /// PingBack API
    /// </summary>
    public class PingBackController : ApiController
    {
        /// <summary>
        /// Get Informantion About the server and Versions
        /// </summary>
        /// <returns></returns>
        [Route("api/")]
        [ResponseType(typeof(ServerInfoModel))]
        public IHttpActionResult GetPong()
        {
            var model = new ServerInfoModel
            {
                ServerUtcDateTime = DateTimeOffset.UtcNow,
                ServerLocalDateTime = DateTimeOffset.Now,
                Text = "Estacione API",
                ApiVersion = 0,

                CustomerAppVersion = { { "apple", "0" }, { "google", "0" } },
                ProfessionalAppVersion = { { "apple", "0" }, { "google", "0" } },

                CustomerMinAppVersionRequired = { { "apple", "0" }, { "google", "0" } },
                ProfessionalMinAppVersionRequired = { { "apple", "0" }, { "google", "0" } },

                CustomerAppStoresUrls = { { "apple", "" }, { "google", "market://details?id=com.parkandgo.driver" } },
                ProfessionalAppStoresUrls = { { "apple", "" }, { "google", "market://details?id=com.parkandgo.professional" } },
            };
            return Ok(model);
        }

    }
}