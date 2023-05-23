CREATE PROCEDURE [dbo].[ObtenerPozosPorContrato_AdmonPozosTanques] @IdContrato INT
AS
BEGIN
    SELECT CO_Instalacion.IdInstalacion,
           LTRIM(RTRIM(CO_Instalacion.NombreInstalacion)) AS NombreInstalacion,
           LTRIM(RTRIM(CO_Instalacion.NombreInstalacionAlterno)) AS NombreInstalacionAlterno,
           CASE
               WHEN ISNULL(PD_Campo.IdYacimiento, 0) = 0 THEN
                   PD_Campo.NombreCampo
               ELSE
                   CAST(CO_Instalacion.IdCampo AS VARCHAR(10))
           END AS IdCampo,
           CO_Instalacion.IdCampo IdCampoMostrar,
           CO_Instalacion.IdCatalogoSCIEP,
           ISNULL(CO_Instalacion.Activo, 0) Activo,
           CO_Instalacion.WelIID,
           PD_Campo.NombreCampo
    FROM CO_Instalacion (NOLOCK)
        INNER JOIN CO_Contrato (NOLOCK)
            ON CO_Instalacion.IdAreaContractual = CO_Contrato.IdAreaContractual
               AND CO_Instalacion.IdActividad = 5
               AND CO_Contrato.IdContrato = @IdContrato
        INNER JOIN PD_Campo (NOLOCK)
            ON CO_Instalacion.IdCampo = PD_Campo.IdCampo
    WHERE CO_Contrato.IdContrato = @IdContrato
    GROUP BY CO_Instalacion.IdInstalacion,
             CO_Instalacion.NombreInstalacion,
             CO_Instalacion.NombreInstalacionAlterno,
             CO_Instalacion.IdCampo,
             ISNULL(PD_Campo.IdYacimiento, 0),
             CO_Instalacion.IdCatalogoSCIEP,
             ISNULL(CO_Instalacion.Activo, 0),
             CO_Instalacion.WelIID,
             PD_Campo.NombreCampo
    ORDER BY CO_Instalacion.IdInstalacion DESC
END