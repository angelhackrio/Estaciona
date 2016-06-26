using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ParkAndGoBackend.Models
{
    /// <summary>
    /// Server Info Data
    /// </summary>
    public class ServerInfoModel
    {
        /// <summary>
        /// UTC Date Time
        /// </summary>
        public DateTimeOffset ServerUtcDateTime { get; set; }

        /// <summary>
        /// Local Date Time of The Server
        /// </summary>
        public DateTimeOffset ServerLocalDateTime { get; set; }

        /// <summary>
        /// Info
        /// </summary>
        public string Text { get; set; }

        /// <summary>
        /// The API Version Number
        /// </summary>
        public int ApiVersion { get; set; }


        /// <summary>
        /// Current Customer Version of Apps In the Stores
        /// </summary>
        public Dictionary<string, string> CustomerAppVersion { get; set; } = new Dictionary<string, string>();

        /// <summary>
        /// Current Professional Version of Apps In the Stores
        /// </summary>
        public Dictionary<string, string> ProfessionalAppVersion { get; set; } = new Dictionary<string, string>();

        /// <summary>
        /// Current Minimal Version that is Required to Run. (Customer)
        /// </summary>
        public Dictionary<string, string> CustomerMinAppVersionRequired { get; set; } = new Dictionary<string, string>();

        /// <summary>
        /// Current Minimal Version that is Required to Run. (Professional)
        /// </summary>
        public Dictionary<string, string> ProfessionalMinAppVersionRequired { get; set; } = new Dictionary<string, string>();

        /// <summary>
        /// Link for The Respective Store App (App Customer)
        /// </summary>
        public Dictionary<string, string> CustomerAppStoresUrls { get; set; } = new Dictionary<string, string>();

        /// <summary>
        /// Link for The Respective Store App (App Professional)
        /// </summary>
        public Dictionary<string, string> ProfessionalAppStoresUrls { get; set; } = new Dictionary<string, string>();
    }
}