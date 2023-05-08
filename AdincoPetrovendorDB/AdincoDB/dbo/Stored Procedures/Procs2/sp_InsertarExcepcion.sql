CREATE PROCEDURE [dbo].[sp_InsertarExcepcion] 
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

@Detalle   NVARCHAR(MAX),
@Ubicacion NVARCHAR(MAX)
AS
     BEGIN
         DECLARE @Fecha AS DATETIME= GETDATE();
         SET NOCOUNT ON;
         INSERT INTO dbo.AP_Excepciones
         (Detalle,
          Ubicacion,
          Fecha
         )
         VALUES
         (@Detalle,
          @Ubicacion,
          @Fecha
         );
     END;

