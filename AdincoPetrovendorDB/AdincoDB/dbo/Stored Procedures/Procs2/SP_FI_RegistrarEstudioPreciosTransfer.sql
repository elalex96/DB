CREATE PROCEDURE [dbo].[SP_FI_RegistrarEstudioPreciosTransfer]
-- Add the parameters for the stored procedure here
@IdContrato         INT, 
@Nombre             NVARCHAR(MAX), 
@Descripcion        NVARCHAR(MAX), 
@Folio              NVARCHAR(20), 
@IdUsuario          INT, 
@ComprobantePDFByte IMAGE, 
@IdSubcontratista   INT, 
@feInicio           DATE, 
@feFin              DATE, 
@feSIPAC            DATE
AS
     BEGIN
         -- =============================================
         -- Author:		Manuel Cruz
         -- Create date: 11-10-17
         -- Description:	
         -- =============================================
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @IdEpt INT;
         -- Insert statements for procedure here
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
         SET @IdEpt = @@IDENTITY;
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj, 
                @IdEpt;
     END;