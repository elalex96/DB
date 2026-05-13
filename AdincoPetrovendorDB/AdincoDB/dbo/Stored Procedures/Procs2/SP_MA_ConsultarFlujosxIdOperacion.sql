-- =============================================
-- Author:		DANIEL AC
-- Create date: 24-01-18
-- Description:	consultar información de flujo por IdOperacion
-- =============================================
CREATE PROCEDURE [dbo].[SP_MA_ConsultarFlujosxIdOperacion]
    -- Add the parameters for the stored procedure here
    @IdOperacion INT,
    @IdContrato INT,
    @IdUsuario INT = 0,
    @IdSubcontratista INT = 0,
    @FechaRegistro DATETIME = '25-01-2017 00:00'
AS
BEGIN
    SET NOCOUNT ON;

    SELECT F.IdFlujo,
           F.Nombre AS NombreFlujo,
           F.IdTipoOperacion,
           F.Descripcion AS DescripcionFlujo,
           F.IdTipoFlujo,
           TF.TipoFlujo,
           TOF.Nombre AS TipoOperacion,
           O.IdEstatusOperacion,
           E.Nombre AS NombreEstatusOperacion,
		   U.UsuarioID,
		   U.Nombre,
		   U.Usuario,
		   O.IdDocumento
    FROM dbo.MA_Flujo AS F
        INNER JOIN dbo.MA_TipoFlujo AS TF
            ON TF.IdTipoFlujo = F.IdTipoFlujo
        INNER JOIN dbo.MA_TipoOperacion AS TOF
            ON TOF.IdTipoOperacion = F.IdTipoOperacion
        INNER JOIN dbo.MA_Operacion AS O
            ON O.IdFlujo = F.IdFlujo
        INNER JOIN dbo.MA_Estatus AS E
            ON E.IdEstatus = O.IdEstatusOperacion
		INNER JOIN dbo.AP_Usuario AS u ON 
		O.IdUsuarioRegistro= U.UsuarioID
    WHERE O.IdOperacion = @IdOperacion
          AND F.IdContrato = @IdContrato;
END;

