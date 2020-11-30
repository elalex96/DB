-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EP_ValidarUsuariosXProveedor]
--@IdPedido INT,
--@IdUsuarioEvaluador INT,
@IdProveedorEvaluador INT,
@IdProveedorSession INT,
@IdUsuario INT, 

--parametros del contrato
@IdContrato INT,
@FechaRegistro DATETIME

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--DECLARE @IdProveedorEvaluador INT = (SELECT IdProveedor from dbo.S_UsuarioProveedor WHERE IdUsuario = @IdUsuarioEvaluador)

	--DECLARE @IdProveedorSession INT = ( SELECT IdProveedor from dbo.S_UsuarioProveedor WHERE IdUsuario = @IdUsuario AND )

	IF (@IdProveedorEvaluador = @IdProveedorSession)
	BEGIN
	SELECT 'PERTENECE_A_LA_EMPRESA'
	END 
	ELSE
	SELECT 'NO_PERTENECE_A_LA_EMPRESA'


END
