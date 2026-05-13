-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2018097
-- Description:	Aprueba o rechaza un calculo
-- =============================================

CREATE PROCEDURE sp_SCOC_VerificaContratosFaltantes --3,10061
    -- Add the parameters for the stored procedure here
    @idContrato INT,
    @idUsuario INT
AS
BEGIN

    SET NOCOUNT ON;
    --SELECT UsuarioID,
    --       P.idContrato,
    --       C.NumeroContrato 
		  -- as NumeroContrato
    --FROM AP_PermisosUsuarios P
    --    JOIN Co_Contrato C
    --        ON P.IdContrato = C.idContrato
    --    JOIN SCOC_EnvioNotificacion EN
    --        ON EN.IdContrato = C.idContrato
    --WHERE UsuarioID = @idUsuario
    --      AND idPermiso = 6
    --      AND AprobadoSCOC = 0 AND EnviadoContratista=1 ; --Aprobación Volumenes SCOC =6

	 SELECT UsuarioID,
           P.idContrato,
           C.NumeroContrato 
		   as NumeroContrato
    FROM AP_PermisosUsuarios P
        JOIN Co_Contrato C
            ON  C.idContrato= @idContrato
        JOIN SCOC_EnvioNotificacion EN
            ON EN.IdContrato = C.idContrato
    WHERE UsuarioID = @idUsuario
          AND idPermiso = 6
          AND AprobadoSCOC = 0 AND EnviadoContratista=1 ; --Aprobación Volumenes SCOC =6


END;
