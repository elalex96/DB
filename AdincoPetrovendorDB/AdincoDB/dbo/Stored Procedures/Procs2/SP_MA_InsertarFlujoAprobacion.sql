-- =============================================
-- Author:		DANIEL AC
-- Create date: 24-01-18
-- Description:	Inserta un flujo de aprobación
-- =============================================
CREATE PROCEDURE [dbo].[SP_MA_InsertarFlujoAprobacion]
-- Add the parameters for the stored procedure here
@NombreFlujo NVARCHAR(500),
@Descripcion NVARCHAR(600),
@IdTipoFlujo INT,
@IdTipoOperacion INT,
@IdContrato INT,
@Predeterminado BIT,
@IdCreadoPor INT,
@IdSubcontratista INT =0,
@FechaRegistro DATETIME= '25-01-2017 00:00'

AS
BEGIN
    SET NOCOUNT ON;
            
			DECLARE @insertado INT 
			
			INSERT INTO dbo.MA_Flujo
			(
			    Nombre,
			    Descripcion,
			    IdTipoFlujo,
			    IdTipoOperacion,
			    IdContrato,	
				Activo		  , 
			    Predeterminado,
			    CreadoPor,
			    CreadoEl,
				IsEliminado
			  
			)
			VALUES
			(  @NombreFlujo,       -- Nombre - nvarchar(500)
			   @Descripcion,       -- Descripcion - nvarchar(600)
			   @IdTipoFlujo,         -- IdTipoFlujo - int
			   @IdTipoOperacion,         -- IdTipoOperacion - int
			   @IdContrato,         -- IdContrato - int
			   1,      -- Activo - bit
			   @Predeterminado,      -- Predeterminado - bit
			   @IdCreadoPor,         -- CreadoPor - int
			   GETDATE(), -- CreadoEl - datetime			   
			   0          -- IsEliminado - int
			   )

			   SELECT @insertado = @@IDENTITY; 
         
			   SELECT @insertado,'SUCCCESS'
             
END;

