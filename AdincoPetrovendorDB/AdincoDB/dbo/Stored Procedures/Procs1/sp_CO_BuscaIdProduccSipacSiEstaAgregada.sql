-- =============================================
-- Author:		Reyna Olvera
-- Create date: 23/02/2018
-- Description:	Verifica si ya esta insertado el volumen  de ese contrato y fecha
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_BuscaIdProduccSipacSiEstaAgregada]
    -- Add the parameters for the stored procedure here
    @fechaMesDiaAnio DATE,
    @hidrocarburo    INT,
    @PuntoEntrega    INT,
    @idContrato      INT,
    @idUsuario       INT = 0
AS
    BEGIN

        SET NOCOUNT ON;

        DECLARE @puntoEntregaContratoId INT;
        SELECT
            @puntoEntregaContratoId = PuntoEntregaContratoID
        FROM
            [CO_PuntosdeEntregaContrato]
        WHERE
            PuntoEntregaID = @PuntoEntrega
            AND idContrato = @idContrato;

        SELECT
                idProduccionMensualSipac,
                VolumenProgramado,
                idUnidadMedida,
                CASE PR.idHidrocarburo
                    WHEN 1001
                        THEN
                        ISNULL(CV.GradosAPI, ISNULL(PR.GradosAPI, 0))
                    ELSE
                        0
                END AS GradosAPI
        FROM
                PR_ProduccionMensualSipac PR
            LEFT JOIN
                CO_Cromatografia          C
                    ON PR.idContrato = C.IdContrato
                       AND PR.idFecha = DATEFROMPARTS(C.Anio, C.Mes, 1)
            LEFT JOIN
                CO_CromatografiaValores   CV
                    ON C.IdCromatografia = CV.IdCromatografia
                       AND CV.IdPuntoEntregaContrato = @puntoEntregaContratoId
        WHERE
                PR.idFecha = @fechaMesDiaAnio
                AND PR.idHidrocarburo = @hidrocarburo
                AND PR.PuntoEntregaID = @PuntoEntrega
                AND PR.idContrato = @idContrato;
    END;