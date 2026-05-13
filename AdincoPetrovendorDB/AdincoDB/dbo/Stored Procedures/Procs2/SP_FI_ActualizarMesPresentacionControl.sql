-- =============================================
-- Author:		Marcos Garcia
-- Create date: 15-06-2020
-- Description:	Update MesPresentacion a Control de Parcialidades
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ActualizarMesPresentacionControl] 
-- ============================================= 
@IdControlPPDC   INT, 
@MesPresentacion DATE, 
@IdContrato      INT, 
@IdUsuario       INT
AS
     BEGIN
         -- =============================================  
         UPDATE dbo.FI_ControlPPDComplementos
           SET 
               MesPresentacion = @MesPresentacion, 
               ModificadoPor = @IdUsuario, 
               ModificadoEl = GETDATE()
         WHERE IdControlPPDC = @IdControlPPDC;
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
             -- =============================================
     END;