-- =============================================
-- Author:		Manuel CD
-- ALTER date: 28-08-17
-- Description:	
-- =============================================
-- Modificado Por: Neri Garcia
-- Fecha: 11 de Agosto del 2022
-- Detalles: Agregado de NOLOCK y Nombrado de Tablas en select
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_TipoMoneda] @DatoBancarioID INT
AS
BEGIN
    SET NOCOUNT ON;
    --
    SELECT PV_TipoMoneda.IdMoneda,
           PV_TipoMoneda.TipoMonedaCorto
    FROM PV_CuentaBancaria (NOLOCK)
        JOIN PV_TipoMoneda
            ON PV_CuentaBancaria.TipoMonedaID = PV_TipoMoneda.IdMoneda
    WHERE PV_CuentaBancaria.DatoBancarioID = @DatoBancarioID
END
