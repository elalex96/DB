-- =============================================
-- Author:		DANIEL AC
-- Create date: 24-01-18
-- Description:	Consultar los tipos de flujos 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MA_ConsultarTipoFlujo]
-- Add the parameters for the stored procedure here
@IdContrato	INT=0,
@IdUsuario  INT = 0,
@IdSubcontratista INT =0,
@FechaRegistro DATETIME= '25-01-2017 00:00'

AS
BEGIN
    SET NOCOUNT ON;
	SELECT IdTipoFlujo,TipoFlujo FROM dbo.MA_TipoFlujo WHERE ISNULL(IsEliminado,0)=0 ORDER BY TipoFlujo ASC 
END; 

