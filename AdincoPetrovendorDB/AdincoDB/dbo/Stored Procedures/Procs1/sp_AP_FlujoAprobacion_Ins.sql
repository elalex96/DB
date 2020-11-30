CREATE PROC sp_AP_FlujoAprobacion_Ins
(@FlujoAprobacionId     INT, 
 @IdContratista         INT, 
 @Descripcion           VARCHAR(8000), 
 @TipoFlujoAprobacionId SMALLINT, 
 @CreadoPor             INT
)
AS
    BEGIN
        SELECT @FlujoAprobacionId = ISNULL(MAX(FlujoAprobacionId), 0) + 1
        FROM AP_FlujoAprobacion;
        INSERT INTO AP_FlujoAprobacion
        (FlujoAprobacionId, 
         IdContratista, 
         Descripcion, 
         TipoFlujoAprobacionId, 
         Activo, 
         CreadoEl, 
         CreadoPor
        )
        VALUES
        (@FlujoAprobacionId, 
         @IdContratista, 
         @Descripcion, 
         @TipoFlujoAprobacionId, 
         1, 
         GETDATE(), 
         @CreadoPor
        );
        SELECT FlujoAprobacionId = @FlujoAprobacionId;
    END;