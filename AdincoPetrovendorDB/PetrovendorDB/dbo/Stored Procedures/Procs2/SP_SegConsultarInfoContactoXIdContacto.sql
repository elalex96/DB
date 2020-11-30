-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_SegConsultarInfoContactoXIdContacto]
@IdContacto int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select CPA.IdContacto, CPA.Nombres,CPA.Apellidos,CPA.Email,CPA.Telefono,CPA.Titulo,CPA.Puesto,CPA.Celular_VENTAS,TC.IdTipoContacto,TC.NombreTipoContacto,CPA.IsPredeterminado
	from S_Contacto_PA CPA
	inner join S_TipoContacto TC
	on CPA.IdTipoContacto = TC.IdTipoContacto
	where CPA.IdContacto = @IdContacto
END

