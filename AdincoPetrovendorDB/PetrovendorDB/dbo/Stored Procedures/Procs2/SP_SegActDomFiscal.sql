-- =============================================
-- Author:		Manuel Cruz
-- Create date: 26-01-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_SegActDomFiscal]
	-- Add the parameters for the stored procedure here
	@IdUsuario int,
	@entidad nvarchar(50),
	@municipio nvarchar(50),
	@colonia nvarchar(50),
	@tipovialidad nvarchar(50),
	@nombrevialidad nvarchar(50),
	@numexterior nvarchar(8),
	@numinterior nvarchar(8),
	@codpostal nvarchar(10),
	@IdProveedor INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	update dbo.S_Proveedor
	set
	Entidad = @entidad,
	Municipio = @municipio,
	Colonia = @colonia,
	TipoVialidad = @tipovialidad,
	NombreVialidad = @nombrevialidad,
	NumExterior = @numexterior,
	NumInterior = @numinterior,
	CodigoPostal = @codpostal
	from S_Proveedor P
	join S_UsuarioProveedor UP on UP.IdProveedor = P.IdProveedor
	join S_Usuario U ON UP.IdUsuario = U.IdUsuario
	where U.IdUsuario = @idusuario AND up.IdProveedor=@IdProveedor

	select concat ( 'Sus datos' , @IdUsuario , ' han sido actualizados') as Mensaje

END
