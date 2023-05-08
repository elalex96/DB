-- =============================================
-- Author:		Reyna Olvera
-- Create date: 07-10-2019
-- Description:	select anuncios 
-- =============================================
CREATE PROCEDURE sp_CO_SelectAnuncios
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SELECT IdAnuncio,
           idContrato,
           Anuncio,
           URL,
           FechaInicio,
           FechaVigencia,
           DiasNovedad,
           u.Nombre as UsuarioCreo,
          a. CreadoEl,
           uM.Nombre AS UsuarioModifico,
          a. ModificadoEl
    FROM co_anuncio a
        JOIN dbo.AP_Usuario u
            ON a.CreadoPor = u.UsuarioID
        LEFT JOIN dbo.AP_Usuario uM
            ON a.ModificadoPor = uM.UsuarioID;
END;