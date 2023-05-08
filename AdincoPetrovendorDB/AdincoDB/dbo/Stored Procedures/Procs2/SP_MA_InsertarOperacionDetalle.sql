

-- =============================================
-- Author:		DANIEL AC
-- Create date: 25-01-18
-- Description:	Insertar Operacion detalle para aprobación 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MA_InsertarOperacionDetalle]
-- Add the parameters for the stored procedure here
@IdAprobador INT,
@NoSecuencia INT,
@IdOperacion INT,
@IdContrato	INT=0,
@IdSubcontratista INT =0,
@FechaRegistro DATETIME= '25-01-2017 00:00'

AS
BEGIN
    SET NOCOUNT ON;
            
			DECLARE @insertado INT 
			
				INSERT INTO dbo.MA_OperacionDetalle
				(
				    IdAprobador,
				    IdEstatus,
				    Comentario,
				    FechaRegistro,				   
				    Activo,
				    NoSecuencia,
				    IdOperacion,
				    IsEliminado,
				    IdFirma,
					IdContrato
				)
				VALUES
				(   @IdAprobador,         -- IdAprobador - int
				    1,         -- IdEstatus - int
				    N'',       -- Comentario - nvarchar(max)
				    GETDATE(), -- FechaRegistro - datetime
				    1,      -- Activo - bit
				    @NoSecuencia,         -- NoSecuencia - int
				    @IdOperacion,         -- IdOperacion - int
				    0,      -- IsEliminado - bit
				    N'',        -- IdFirma - nvarchar(35)
					@IdContrato -- IdContrato - int
				    )

			   SELECT @insertado = @@IDENTITY;          
			   SELECT @insertado,'SUCCCESS'
             
END;
