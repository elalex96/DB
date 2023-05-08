-- =============================================
-- Author:		DANIEL AC
-- Create date: 24-01-18
-- Description:	Inserta Aprobador al flujo de aprobación
-- =============================================
CREATE PROCEDURE [dbo].[SP_MA_InsertarAprobador]
-- Add the parameters for the stored procedure here
@IdFlujo INT,
@NoSecuencia INT,
@IdUsuario INT ,
@IdSubcontratista INT ,
@IdContrato INT ,
@CreadoPor INT,
@FechaRegistro DATETIME= '25-01-2017 00:00'

AS
BEGIN
    SET NOCOUNT ON;
            
			DECLARE @insertado INT 
			
			INSERT INTO dbo.MA_Aprobador
			(
			    IdFlujo,
			    NoSecuencia,
			    IdUsuario,
			    IdSubcontratista,
			    IdContrato,
			    CreadoPor,
			    CreadoEl
			   
			)
			VALUES
			(   @IdFlujo,         -- IdFlujo - int
			    @NoSecuencia,         -- NoSecuencia - int
			    @IdUsuario,         -- IdUsuario - int
			    @IdSubcontratista,         -- IdSubcontratista - int
			    @IdContrato,         -- IdContrato - int
			    @CreadoPor,         -- CreadoPor - int
			    GETDATE() -- CreadoEl - datetime			   
			    )

			   SELECT @insertado = @@IDENTITY; 
         
			   SELECT @insertado,'SUCCCESS'
             
END;

