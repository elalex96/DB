CREATE PROC sp_AP_FlujoAprobacionContratos_Ins
(@FlujoAprobacionId INT, 
 @IdContrato        INT
)
AS
    BEGIN
        INSERT INTO AP_FlujoAprobacionContratos
        (FlujoAprobacionId, 
         IdContrato, 
         CreadoEl
        )
        VALUES
        (@FlujoAprobacionId, 
         @IdContrato, 
         GETDATE()
        );
    END;