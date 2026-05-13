-- =============================================
-- Author:  Daniel AC
-- Create date: 10/06/2020
-- Description: Obtener contratos por usuario
-- =============================================
CREATE  PROCEDURE [dbo].[sp_SDK_EN_ObtenerContratosPorUsuario]
    -- Add the parameters for the stored procedure here
    @IdUsuario INT = 0
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
     SET NOCOUNT ON;
    SELECT U.UsuarioID AS UsuarioId,
           U.Idioma,
           C.NumeroContrato,
           AC.NombreAreaContractual,
           C.NumeroContrato + ' - ' + AC.NombreAreaContractual AS Contrato,
           C.IdContrato,
           AC.IdAreaContractual,
           C.FechaArranqueEntregables,
           C.FinVigencia,
           CC.Color_Hex
    FROM CO_Contrato C (NOLOCK)
        JOIN CO_AreaContractual AC (NOLOCK)
            ON C.IdAreaContractual = AC.IdAreaContractual
        JOIN AP_Perfil P (NOLOCK)
            ON C.IdContrato = P.IdContrato
        JOIN AP_PerfilUsuario AS PU (NOLOCK)
            ON P.IdPerfil = PU.PerfilID
               AND PU.UsuarioID = @IdUsuario
        JOIN AP_Usuario U (NOLOCK)
            ON PU.UsuarioID = U.UsuarioID    
        LEFT JOIN CO_ContratoConfiguracion CC (NOLOCK)
            ON C.IdContrato =   CC.IdContrato
    GROUP BY U.UsuarioID,
             U.Idioma,
             C.NumeroContrato,
             AC.NombreAreaContractual,
             C.NumeroContrato + ' - ' + AC.NombreAreaContractual,
             C.IdContrato,
             AC.IdAreaContractual,
             C.FechaArranqueEntregables,
             C.FinVigencia,
             CC.Color_Hex
 
END;