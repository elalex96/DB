-- =============================================
-- Author:		Manuel CD
-- ALTER date: 04-09-17
-- Description:	
-- =============================================
-- Modificado Por: Neri Garcia
-- Fecha: 11 de Agosto del 2022
-- Detalles: Agregado de NOLOCK y Nombrado de Tablas en select
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_PVMetodoPago]
AS
BEGIN
    SET NOCOUNT ON;
    --
    SELECT PV_MetodoPago.IdMetodoPago,
           PV_MetodoPago.MetodoPago
    FROM PV_MetodoPago (NOLOCK)
    ORDER BY PV_MetodoPago.Orden ASC;
END;
