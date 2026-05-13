-- =============================================
-- Author:		DANIEL AC
-- Create date: 24-01-18
-- Description:	Consultar los tipos de operaciones 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MA_ConsultarTipoOperacion]
-- Add the parameters for the stored procedure here
@IdContrato	INT=0,
@IdUsuario  INT = 0,
@IdSubcontratista INT =0,
@FechaRegistro DATETIME= '25-01-2017 00:00'

AS
BEGIN
    SET NOCOUNT ON;
	SELECT IdTipoOperacion,Nombre FROM dbo.MA_TipoOperacion WHERE  Activo=1 AND ISNULL(IsEliminado,0)=0
END; 

