CREATE PROC sp_AP_FlujoAprobacionContratos_Del(@FlujoAprobacionId INT)
AS
    BEGIN
        DELETE FROM AP_FlujoAprobacionContratos
        WHERE FlujoAprobacionId = @FlujoAprobacionId;
    END;