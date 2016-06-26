using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ParkAndGoBackend.Entity.Estacionamento
{
    [Table("Estacionamentos", Schema = "Estacionamento")]
    public class Estacionamento
    { 
        [Key, Required]
        public virtual Guid Id { get; set; }

        [Required, StringLength(256)]
        public virtual string Nome { get; set; }
        [Required, StringLength(1024)]
        public virtual string Descricao { get; internal set; }
        [Required, StringLength(256)]
        public virtual string EmpresaResponsavel { get; internal set; }
        [Required, Range(0, 10000) ]
        public virtual long? PrecoDoIntervaloEmCentavos { get; set; }

        [Required, Range(0, 1024)]
        public virtual int? IntervaloEmHoras { get; set; }
    }
}