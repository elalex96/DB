
 

-- =============================================
CREATE  PROCEDURE [dbo].[SP_DEA_AdjuntoEnviarCorreo]
    -- Add the parameters for the stored procedure here
    
    @IdProveedor INT ,
    @IdUsuario INT,    
    @IdNotificacion INT,
    @NombreArchivo NVARCHAR(MAX),
    @Adjunto IMAGE

 

AS
BEGIN
    
    
          DECLARE @IdNotificacionAdjunto BIGINT
          SET @IdNotificacionAdjunto = (ISNULL((SELECT MAX(IdNotificacionAdjunto) FROM Adinco.dbo.S_NotificacionAdjunto),1000) + 1)
     

 

         INSERT INTO Adinco.dbo.S_NotificacionAdjunto
         (
             IdNotificacionAdjunto,
             IdNotificacion,
             NombreArchivo,
             Adjunto,
             CreadoPor,
             CreadoEl
         )
         VALUES
         (   @IdNotificacionAdjunto,        -- IdNotificacionAdjunto - bigint
             @IdNotificacion,        -- IdNotificacion - bigint
             @NombreArchivo,       -- NombreArchivo - varchar(250)
             @Adjunto,     -- Adjunto - image
             3,        -- CreadoPor - int
             GETDATE() -- CreadoEl - datetime
           )
    
      SELECT @IdNotificacionAdjunto
END
 