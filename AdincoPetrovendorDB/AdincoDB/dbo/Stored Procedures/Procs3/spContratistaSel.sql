
create proc spContratistaSel
(
	@pIdContratista	int,
	@pIdContrato	int
)
as
begin
	select		c.IdContratista,
				c.NombreContratista,
				c.Representante,
				c.PuestoRepresentante,
				c.RazonSocial,
				c.Calle,
				c.Numero,
				c.Colonia,
				c.Municipio,
				c.Entidad,
				c.CodigoPostal,
				c.Pais,
				c.RFC,
				c.CorreoElectronico,
				c.Telefono,
				c.PaginaWeb,
				c.DocumentoLegal,
				c.IDSIPAC,
				c.CreadoPor,
				c.LogoHTML,
				c.IdProveedor,
				c.Logo,
				c.DefaultPage,
				c.IdRuta
	from		CO_Contratista		c
	inner join	CO_Contrato			co
	on			co.IdContratista	=	c.IdContratista
	where		((co.IdContrato		=	@pIdContrato)		or	@pIdContrato	= -1)
	and			((co.IdContratista	=	@pIdContratista)	or	@pIdContratista	= -1)
end

