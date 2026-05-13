
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 12-02-18
-- Description: Consultar estatus actual de aprobador de compra directa 
-- =============================================
CREATE PROCEDURE [dbo].[SP_CD_ConsultarEstatusAprobadorCompraDirecta] 
    -- Add the parameters for the stored procedure here
    
    @IdUsuario INT,      
    @IdOperacion INT,      
    @IdContrato INT = 0,
    @FechaRegistro DATETIME = '12-02-2018'


AS
BEGIN

    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


	SELECT IdEstatus FROM  dbo.TA_Tarea
	INNER JOIN dbo.TA_Operacion ON TA_Operacion.IdOperacion = TA_Tarea.IdOperacion
	WHERE IdAprobador=@IdUsuario AND  TA_Operacion.IdOperacion=@IdOperacion

END 

