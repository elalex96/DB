
CREATE PROCEDURE dbo.SP_PC_ConsultaPuntosVenta
@IdContrato INT,
@MesReporte NVARCHAR(10),
@IdUsuario  INT
AS
     BEGIN
-- =============================================
-- Author:		Manuel CD
-- Create date: 25-10-2017
-- Description:	
-- =============================================
SET NOCOUNT ON
SET LANGUAGE spanish


    SELECT PVP.IdPuntoVentaProducto,
        PVP.Mes AS 'Fecha de reporte',
        PV.Denominacion AS 'Punto de venta',
        M.TextoBreve AS 'Producto',
        PVP.Aplica AS 'SI/NO'
    FROM PC_PuntoVentaProducto PVP
        JOIN PC_PtoExpedicionRecepcion PV ON PVP.IdPtoExpedicionRecepcion = PV.IdPtoExpedicionRecepcion
        JOIN PC_Material M ON PVP.IdMaterialPC = M.IdMaterialPC
    WHERE PVP.IdContrato = @IdContrato
        AND CONVERT(VARCHAR(11), Mes, 103) = @MesReporte
--SELECT CONVERT(VARCHAR(11), Mes, 101) FROM PC_PuntoVentaProducto
END

