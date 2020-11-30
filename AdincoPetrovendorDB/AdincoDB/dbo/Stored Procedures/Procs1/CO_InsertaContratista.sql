-- =============================================
-- Author:		Reyna Olvera
-- Create date: 01/06/2018
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[CO_InsertaContratista] 
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
@idContrato int,
@idUsuario int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Insert into co_contratista(
	NombreContratista,
	Representante,
	PuestoRepresentante,
	RazonSocial,
	Calle,
	Numero,
	Colonia,
	Municipio,
	Entidad,
	CodigoPostal,
	Pais,
	RFC,
	CorreoElectronico,
	Telefono,
	PaginaWeb,
	DocumentoLegal,
	idSipac,
	idProveedor,
	Logo,
	CreadoPor
	)
	values(
	@NombreContratista,
	@Representante,
	@PuestoRepresentante,
	@RazonSocial,
	@Calle,
	@Numero,
	@Colonia,
	@Municipio,
	@Entidad,
	@CodigoPostal,
	@Pais,
	@RFC,
	@CorreoElectronico,
	@Telefono,
	@PaginaWeb,
	@DocumentoLegal,
	@idSipac,
	@idProveedor,
	@Logo,
	@idUsuario
	)
	
END
