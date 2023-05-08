CREATE PROCEDURE [dbo].[SP_PC_ContFact]
	-- Add the parameters for the stored procedure here
@IdTipoExcel INT,
@IdContrato  INT,
@MesReporte	DATE,
@IdUsuario   INT
AS
BEGIN
-- =============================================
-- Author:		Manuel CD
-- Create date: 06-11-17
-- Description:	
----------------------------------------------------
-- 20190108	BAAC	Se agrega el mes de reporte para validar solo las facturas faltantes del mes a reportar
-- =============================================
    SET NOCOUNT ON;

-- Insert statements for procedure here
    IF(@IdTipoExcel = 10002)
        BEGIN
            SELECT COUNT(P.UUID)
            FROM PC_PMI AS P
                LEFT JOIN FI_Factura AS F ON F.UUID = P.UUID
            WHERE
			DATEFROMPARTS( SUBSTRING( P.[FECHA TIMBRADO], 7, 4 ), SUBSTRING( P.[FECHA TIMBRADO], 4, 2 ), 1 )	=	@MesReporte
			AND F.IdFactura IS NULL
    END;
    IF(@IdTipoExcel = 10003)
        BEGIN
            SELECT COUNT(P.UUID)
            FROM PC_PTI AS P
                LEFT JOIN FI_Factura AS F ON F.UUID = P.UUID
            WHERE
			DATEFROMPARTS( SUBSTRING( P.[FECHA TIMBRADO], 7, 4 ), SUBSTRING( P.[FECHA TIMBRADO], 4, 2 ), 1 )	=	@MesReporte
			AND F.IdFactura IS NULL
    END
END