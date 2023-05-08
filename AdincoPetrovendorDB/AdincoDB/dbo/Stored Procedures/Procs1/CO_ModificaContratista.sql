-- =============================================
-- Author:		Reyna Olvera
-- Create date: 01/06/2018
-- Description:	<Description,,>
-- =============================================
create PROCEDURE CO_ModificaContratista
	-- Add the parameters for the stored procedure here
@NombreContratista nvarchar(Max),
@Representante nvarchar (Max),
@PuestoRepresentante nvarchar(Max),
@RazonSocial nvarchar(Max),
@Calle nvarchar(Max),
@Numero nvarchar(Max),
@Colonia nvarchar(Max),
@Municipio nvarchar(Max),
@Entidad nvarchar(Max),
@CodigoPostal nvarchar(Max),
@Pais nvarchar(Max),
@RFC nvarchar(Max),
@CorreoElectronico nvarchar(Max), 
@Telefono nvarchar(Max),
@PaginaWeb nvarchar(Max),
@DocumentoLegal nvarchar(Max),
@idSipac nvarchar(Max),
@idProveedor int,
@Logo image,
@idContratista int,
@idContrato int,
@idUsuario int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Update co_contratista
Set NombreContratista=@NombreContratista,
Representante=@Representante,
PuestoRepresentante=@PuestoRepresentante,
RazonSocial=@RazonSocial,
Calle=@Calle,
Numero=@Numero,
Colonia=@Colonia,
Municipio=@Municipio,
Entidad=@Entidad,
CodigoPostal=@CodigoPostal,
Pais=@Pais,
RFC=@RFC,
CorreoElectronico=@CorreoElectronico,
Telefono=@Telefono,
PaginaWeb=@PaginaWeb,
DocumentoLegal=@DocumentoLegal,
IDSIPAC=@idSipac,
idProveedor=@idProveedor,
Logo=@Logo
Where idcontratista=@idContratista

END