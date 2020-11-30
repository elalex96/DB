-- =============================================
-- Author:		Alexander Gomez
-- Create date: 26-06-2018
-- Description:	Validacion que el usuario sea aprobador de la factura
-- =============================================
CREATE procedure [dbo].[SP_MPY_FI_ValidarUsuarioAprobador]
@IdUsuario NVARCHAR(MAX),
@IdAceptacionPedido INT
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IDAPROBADOR INT;
	DECLARE @IDESTATUS INT;


	SET @IDESTATUS =  (SELECT TOP 1 AF.IdEstatus
						 FROM dbo.MPY_MM_AceptacionFactura AS AF
						 WHERE AF.IdAceptacionPedido = @IdAceptacionPedido
						 ORDER BY AF.CreadoEl DESC);



	SET @IDAPROBADOR = (SELECT TOP 1 S_RolUsuario
						FROM dbo.S_UsuarioRol
						WHERE IdUsuario = @IdUsuario
							AND IdRol = 1);
		
		SELECT @IDAPROBADOR,@IDESTATUS	

END
