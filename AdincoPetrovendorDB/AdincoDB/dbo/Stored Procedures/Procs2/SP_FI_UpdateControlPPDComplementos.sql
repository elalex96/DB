-- =============================================
-- Author:		Marcos Garcia
-- Create date: 15-06-2020
-- Description:	Update a Control de Parcialidades
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_UpdateControlPPDComplementos] 
-- ============================================= 
@IdControlPPDC INT, 
@Activo       INT, 
@IdContrato    INT, 
@IdUsuario     INT
AS
     BEGIN
         -- =============================================  
         UPDATE dbo.FI_ControlPPDComplementos
           SET 
               Activo = @Activo, 
               ModificadoPor = @IdUsuario, 
               ModificadoEl = GETDATE()
         WHERE IdControlPPDC = @IdControlPPDC;
         -- =============================================
     END;