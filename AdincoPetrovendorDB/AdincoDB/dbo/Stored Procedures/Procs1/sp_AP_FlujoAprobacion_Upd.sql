CREATE PROC sp_AP_FlujoAprobacion_Upd
(@FlujoAprobacionId     INT, 
 @IdContratista         INT, 
 @Descripcion           VARCHAR(8000), 
 @TipoFlujoAprobacionId SMALLINT
)
AS
    BEGIN
        UPDATE AP_FlujoAprobacion
          SET 
              IdContratista = @IdContratista, 
              Descripcion = @Descripcion, 
              TipoFlujoAprobacionId = @TipoFlujoAprobacionId
        WHERE FlujoAprobacionId = @FlujoAprobacionId;
    END;