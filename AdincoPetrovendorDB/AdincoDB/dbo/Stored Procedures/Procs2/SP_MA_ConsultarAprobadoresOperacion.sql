-- =============================================
-- Author:		DANIEL AC
-- Create date: 24-01-18
-- Description:	Insertar Documento para aprobación 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MA_ConsultarAprobadoresOperacion]
-- Add the parameters for the stored procedure here
@IdOperacion INT,
@IdContrato	INT = 0,
@IdUsuario INT = 0,
@IdSubcontratista INT = 0,
@FechaRegistro DATETIME = '26-01-2017 00:00:00'

AS
BEGIN
    SET NOCOUNT ON;
	
			SELECT U.UsuarioID, U.Nombre,U.Usuario, OD.NoSecuencia,OD.Activo,OD.IdEstatus, OD.IdOperacionDetalle, E.Nombre,OD.Comentario
			FROM dbo.AP_Usuario U
			INNER JOIN dbo.MA_OperacionDetalle AS OD ON OD.IdAprobador= U.UsuarioID
			INNER JOIN dbo.MA_Operacion AS O ON O.IdOperacion=OD.IdOperacion
			INNER JOIN dbo.MA_Estatus AS E ON E.IdEstatus = OD.IdEstatus
			WHERE O.IdOperacion=@IdOperacion
END;

