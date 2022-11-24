-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_InsertarExcepcion] 

@Detalle nvarchar(MAX),
@Ubicacion nvarchar(MAX)
AS
BEGIN

declare @Fecha as datetime = GETDATE()

SET NOCOUNT ON;
-- 
-- INSERT INTO dbo.Excepciones
-- (Detalle,Ubicacion,Fecha)
-- VALUES 
-- (@Detalle,@Ubicacion,@Fecha)

END