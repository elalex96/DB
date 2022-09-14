
USE Petrovendor
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'APP_ConsultarNotificacionDefault'
)
    DROP PROCEDURE APP_ConsultarNotificacionDefault;
GO
-- =============================================
-- Author:	Daniel AC
-- Create date: <30/08/2022>
-- Description:	Validar si el proveedor actual se le debe mostrar notificaciones, siempre y cuando tenga al menos un pedido relacioando con algun contrato
-- =============================================
CREATE PROCEDURE dbo.APP_ConsultarNotificacionDefault
@ProveedorActualId  INT 
AS
BEGIN
SET NOCOUNT ON;

CREATE TABLE #ContratosConPedidos(Id INT Identity(1,1) , IdContrato INT)
CREATE TABLE #Contratos(Id INT Identity(1,1) , IdContrato INT)

DECLARE @FechaActual DATETIME =GETDATE()

-- OBTENER CONTRATOS QUE TIENEN NOTIFICACIONES ACTIVAS Y DENTRO DEL PERIODO DE LA FECHA ACTUAL
INSERT INTO #Contratos(IdContrato)
SELECT ContratoId
FROM APP_NotificacionesDefault 
WHERE @FechaActual BETWEEN FechaInicio AND FechaFinalizacion --> LA FECHA ACTUAL ESTE DENTRO DEL INTERVALO DE LA NOTIFICACIÓN
AND Activo= 1 --> CTE ESTE ACTIVO
GROUP BY ContratoId

-- OBTENER CONTRATOS QUE SI TIENE  PEDIDOS RELACIONADOS AL PROVEEDOR ACTUAL
INSERT INTO #ContratosConPedidos(IdContrato)
SELECT P.IdContrato
FROM dbo.MM_Pedido P
JOIN #Contratos c
ON P.IdContrato= C.IdContrato
WHERE P.IdSubcontratista= @ProveedorActualId
AND ISNULL(P.IdEstatusEliminado,0)=0 --> CTE NO ESTE ELIMINADO
GROUP BY P.IdContrato

-- OBTENER LA LISTA DE NOTIFICACIONES QUE SE DEBEN MOSTRAR AL PROVEEDOR DE PETROVENDOR
SELECT ND.Id, ND.Titulo, ND.Mensaje, ND.FechaInicio, ND.FechaFinalizacion, ND.ContratoId
FROM APP_NotificacionesDefault ND
JOIN #ContratosConPedidos CP
	ON ND.ContratoId = CP.IdContrato
WHERE @FechaActual BETWEEN FechaInicio AND FechaFinalizacion
AND Activo= 1
GROUP BY  ND.Id, ND.Titulo, ND.Mensaje, ND.FechaInicio, ND.FechaFinalizacion, ND.ContratoId
ORDER BY FechaInicio DESC 


END;


