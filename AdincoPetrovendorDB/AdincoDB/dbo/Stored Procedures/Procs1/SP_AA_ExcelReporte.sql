-- =============================================
-- Author:		Manuel CD
-- Create date: 27-11-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_AA_ExcelReporte] 
	-- Add the parameters for the stored procedure here
@IdTipoReporte  INT,
@NombreArchivo  NVARCHAR(MAX),
@FechaReporte   DATE,
@ReporteArchivo IMAGE,
@IdUsuario      INT,
@IdContrato     INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

	    /*Actualizar por contratista*/

             DECLARE @IdContratista INT
		   DECLARE @NomContrato NVARCHAR(50)

             SELECT @IdContratista = CC.IdContratista, @NomContrato = C.NumeroContrato
             FROM CO_Contratista CC
                  JOIN CO_Contrato C ON CC.IdContratista = C.IdContratista
             WHERE C.IdContrato = @IdContrato;
		   SELECT @IdContratista, @NomContrato
/**/

             IF EXISTS
		  (
			 SELECT *
			 FROM AA_ReportesCargados RC
				 JOIN CO_Contrato C ON RC.IdContrato = C.IdContrato
				 JOIN CO_Contratista CC ON C.IdContratista = CC.IdContratista
			 WHERE IdTipoReporte = @IdTipoReporte
				  AND FechaReporte = @FechaReporte
				  AND CC.IdContratista = @IdContratista
		  )
                 BEGIN
                     UPDATE EP
                       SET
                           ReporteArchivo = @ReporteArchivo,
                           CreadoEn = GETDATE(),
                           CreadoPor = @IdUsuario,
                           NombreArchivo = @NombreArchivo
                     FROM AA_ReportesCargados EP
                          JOIN CO_Contrato C ON EP.IdContrato = C.IdContrato
                          JOIN CO_Contratista CC ON C.IdContratista = CC.IdContratista
                     WHERE IdTipoReporte = @IdTipoReporte
                           AND FechaReporte = @FechaReporte
                           AND CC.IdContratista = @IdContratista
                 END
                 ELSE
                 BEGIN
                     INSERT INTO [dbo].[AA_ReportesCargados]
				([IdTipoReporte],
				 [NombreArchivo],
				 [FechaReporte],
				 [ReporteArchivo],
				 [CreadoPor],
				 [CreadoEn],
				 [IdContrato]
				)
                     VALUES
				(@IdTipoReporte,
				 @NombreArchivo,
				 @FechaReporte,
				 @ReporteArchivo,
				 @IdUsuario,
				 GETDATE(),
				 @IdContrato
				)
                 END

			  SET LANGUAGE spanish
			  IF(@IdTipoReporte = 10002)
			  BEGIN
				UPDATE AA_RMP_CONT_34 SET RMPCT34_00 = CONVERT(VARCHAR(10),CONVERT(datetime,CONVERT(int,RMPCT34_00)-2),103) FROM AA_RMP_CONT_34 WHERE RF01_01 = @NomContrato AND LEN(RMPCT34_00) <=5
			  END

             IF @@ERROR <> 0
                 SELECT 'false' AS msj;
                 ELSE
             SELECT 'true' AS msj;

         END;
