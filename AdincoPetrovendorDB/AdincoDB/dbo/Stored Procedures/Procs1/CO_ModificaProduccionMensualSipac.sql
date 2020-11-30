-- =============================================
-- Author:		Reyna  Olvera
-- Create date: 23/02/2018
-- Description:	Modifica la Produccion Mensual de Sipac
-- =============================================
CREATE PROCEDURE [dbo].[CO_ModificaProduccionMensualSipac] 
--
@VolumenProgramado        FLOAT, 
@UnidadMedida             INT, 
@idContrato               INT,
--@GradosAPI float,
@idUsuario                INT, 
@idProduccionMensualSipac INT, 
@fechaMesDiaAño           DATE, 
@puntoEntrega             INT, 
@hidrocarburo             INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         --********Se comento por que los grados API se toman de otra tabla
         -- Insert statements for procedure here
         --Select * from PR_ProduccionMensualSipac
         UPDATE PR_ProduccionMensualSipac
           SET 
               VolumenProgramado = @VolumenProgramado, 
               --[GradosAPI]=@GradosAPI,
               idUnidadMedida = @UnidadMedida, 
               ModificadoPor = @idUsuario, 
               ModificadoEl = GETDATE()
         WHERE --idProduccionMensualSipac = @idProduccionMensualSipac AND 
			   idContrato = @idContrato
               AND idFecha = @fechaMesDiaAño
               AND PuntoEntregaId = @puntoEntrega
               AND idHidrocarburo = @hidrocarburo;
     END;