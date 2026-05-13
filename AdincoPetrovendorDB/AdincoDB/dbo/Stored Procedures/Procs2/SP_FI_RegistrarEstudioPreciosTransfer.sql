
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_RegistrarEstudioPreciosTransfer'
)
    DROP PROCEDURE SP_FI_RegistrarEstudioPreciosTransfer
GO
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 11-10-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_RegistrarEstudioPreciosTransfer]
@IdContrato         INT, 
@Nombre             VARCHAR(8000), 
@Descripcion        VARCHAR(8000), 
@Folio              NVARCHAR(20), 
@IdUsuario          INT, 
@ComprobantePDFByte IMAGE, 
@IdSubcontratista   INT, 
@feInicio           DATE, 
@feFin              DATE, 
@feSIPAC            DATE
AS
     BEGIN

         SET NOCOUNT ON;
         DECLARE @IdEpt INT;

         INSERT INTO [dbo].[FI_EstudioPreciosTransfer]
         ([IdContrato], 
          [Nombre], 
          [Descripcion], 
          [FolioOperacion], 
          [IdClasificacionDocumento], 
          [CreadoPor], 
          [CreadoEn], 
          [Archivo], 
          [ProcesadoSIPAC], 
          [IsEliminado], 
          [IdSubcontratista], 
          [FechaInicioVigencia], 
          [FechaFinVigencia], 
          [FechaCargaSIPAC]
         )
         VALUES
         (@IdContrato, 
          @Nombre, 
          @Descripcion, 
          @Folio, 
          2, 
          @IdUsuario, 
          GETDATE(), 
          @ComprobantePDFByte, 
          0, 
          0, 
          @IdSubcontratista, 
          @feInicio, 
          @feFin, 
          @feSIPAC
         );

         SELECT @IdEpt = SCOPE_IDENTITY();

         IF @@ERROR <> 0
             SELECT 'false' AS msj;
         ELSE
         SELECT 'true' AS msj, @IdEpt;
     END;