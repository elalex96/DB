
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <28-05-2018>
-- Description:	<Se consulta los datos de un registro de gastos por factura>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <21-06-2018>
-- Description:	<Se agrega joins para devolver informacion con nombres de los IDs debido a la modificacion de la card 506_RegistroGasto>
-- =============================================

CREATE procedure [dbo].[SP_MPY_MM_ConsultaRegistroGastoPorFactura]
	@IdFactura INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN

	SELECT r.IdRegistro
	FROM dbo.CO_Registro r
	WHERE r.IdFactura = @IdFactura

END

