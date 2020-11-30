-- ============================================= 
-- Author:    Reyna Olvera 
-- Create date: 20181023 
-- Description:  Guarda Procesos 
-- ============================================= 
CREATE PROCEDURE [dbo].[sp_EN_UpdateProcesos]
  @idContrato            INT, 
  @idUsuario             INT, 
  @IdProceso             INT, 
  @NombreProceso         VARCHAR(1000), 
  @Descripcion           VARCHAR(3000), 
  @IdInstalacion         INT, 
  @IsProcesoEvento       INT, 
  @isSerie               INT, 
  @IsMacroprocesoCalculo INT=0 
AS 
  BEGIN 
      SET nocount ON; 

      DECLARE @Error       NVARCHAR(max)='', 
              @TipoProceso INT; 

      SELECT @TipoProceso = idtipoproceso 
      FROM   en_procesos 
      WHERE  idproceso = @IdProceso 

      UPDATE dbo.en_procesos 
      SET    nombreproceso = @NombreProceso, 
             descripcion = @Descripcion, 
             modificadopor = @idUsuario, 
             modificadoel = Getdate(), 
             activo = 1, 
             isprocesoevento = @IsProcesoEvento, 
             isserie = @isSerie, 
             idtipoproceso = CASE @TipoProceso 
                               WHEN 10000 THEN 10000 
                               ELSE 
                                 CASE @IsMacroprocesoCalculo 
                                   WHEN 0 THEN 10001 
                                   WHEN 1 THEN 10002 
                                 END 
                             END 
      WHERE  idproceso = @IdProceso 

      IF @@ERROR <> 0 
        BEGIN 
            SET @Error = Error_message(); 
        END 

      SELECT @Error; 
  END; 