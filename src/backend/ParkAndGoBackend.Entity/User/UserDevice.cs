using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ParkAndGoBackend.Entity.User
{
    [Table("UserDevices", Schema = "User")]
    public class UserDevice
    {
        [Key, Required]
        public virtual Guid Id { get; set; }

        [Required]
        public virtual string Token { get; set; }
    }
}
