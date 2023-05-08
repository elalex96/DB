-- =============================================
-- Author:		DANIEL AC
-- Create date: 24-01-18
-- Description: Consultar Aporbadores por Flujo de aprobación
-- =============================================
CREATE PROCEDURE [dbo].[SP_MA_ConsultarAprobadoresFlujo]
-- Add the parameters for the stored procedure here
@IdFlujo INT,
@IdContrato INT,
@IdUsuario INT = 0,
@IdSubcontratista INT = 0,
@FechaRegistro DATETIME = '26-01-2017 00:00:00'

AS
BEGIN
    SET NOCOUNT ON;
	
			SELECT U.UsuarioID, U.Nombre,U.Usuario, A.NoSecuencia,A.IdFlujo
			FROM dbo.AP_Usuario U
			INNER JOIN dbo.MA_Aprobador A ON A.IdUsuario=U.UsuarioID
			INNER JOIN dbo.MA_Flujo F ON F.IdFlujo = A.IdFlujo
			WHERE F.IdFlujo=@IdFlujo AND F.IdContrato=@IdContrato
			ORDER BY A.NoSecuencia ASC
END;

