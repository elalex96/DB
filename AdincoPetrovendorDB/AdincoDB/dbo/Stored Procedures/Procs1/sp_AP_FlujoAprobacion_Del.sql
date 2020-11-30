CREATE PROC sp_AP_FlujoAprobacion_Del(@FlujoAprobacionId INT)
AS
    BEGIN
        UPDATE AP_FlujoAprobacion
          SET 
              Activo = 0
        WHERE FlujoAprobacionId = @FlujoAprobacionId;
    END;