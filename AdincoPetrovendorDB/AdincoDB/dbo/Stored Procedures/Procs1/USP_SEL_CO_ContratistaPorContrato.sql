IF OBJECT_ID('dbo.USP_SEL_CO_ContratistaPorContrato', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.USP_SEL_CO_ContratistaPorContrato;
END
GO

CREATE PROCEDURE dbo.USP_SEL_CO_ContratistaPorContrato
    @IdContrato INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        B.IdContratista,
        A.NombreContratista,
        A.LogoHTML,
        DefaultPage = ISNULL(A.DefaultPage, 'default.aspx'),
        A.RFC,
        B.NumeroContrato,
		T.TipoContratoCorto
    FROM CO_Contrato B WITH (NOLOCK)
    INNER JOIN CO_Contratista A WITH (NOLOCK)
        ON B.IdContratista = A.IdContratista
	LEFT JOIN CO_TipoContrato T
		ON B.IdTipoContrato = T.IdTipoContrato
    WHERE B.IdContrato = @IdContrato;
END


GO
