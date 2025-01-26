USE [Adinco]
GO

IF OBJECT_ID('[dbo].[p_SC_Subcontrato_Ins]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[p_SC_Subcontrato_Ins]
GO

CREATE PROCEDURE [dbo].[p_SC_Subcontrato_Ins]
(
    @pIdSubcontrato     INT OUT,
    @pIdSubContratista  INT,
    @pIdContratista     INT,
    @pNumeroSubContrato VARCHAR(MAX),
    @pIdContrato        INT,
    @pIdUsuario         INT,
    @pIdCentroCostos    INT,
    @pIdMoneda          INT,
    @pPrefijoOT         VARCHAR(13),
    @pObjeto            VARCHAR(300),
    @pFechaInicio       DATETIME = NULL,
    @pFechaFin          DATETIME = NULL,
    @pError             VARCHAR(250) = '' OUT
)
AS
BEGIN
    SELECT @pIdSubcontrato = ISNULL(MAX(IdSubContrato), 0) + 1
    FROM SC_Subcontrato (NOLOCK);

    IF NOT EXISTS (
        SELECT 1 
        FROM SC_SubContrato (NOLOCK)
        WHERE NumeroSubContrato = @pNumeroSubContrato
          AND IdContratista = @pIdContratista
          AND IsActivo = 1
    )
    BEGIN
        INSERT INTO SC_SubContrato
        (
            IdSubContrato,
            IdSubContratista,
            IdContratista,
            NumeroSubContrato,
            IdContrato,
            CreadoPor,
            CreadoEl,
            IdCentroCosto,
            IsEliminado,
            IsActivo,
            IdMoneda,
            PrefijoOT,
            Objeto,
            FechaInicio,
            FechaFin
        )
        VALUES
        (
            @pIdSubcontrato,
            @pIdSubContratista,
            @pIdContratista,
            @pNumeroSubContrato,
            @pIdContrato,
            @pIdUsuario,
            GETDATE(),
            @pIdCentroCostos,
            0,
            1,
            @pIdMoneda,
            'OT-' + @pPrefijoOT,
            @pObjeto,
            @pFechaInicio,
            @pFechaFin
        );
    END
    ELSE
    BEGIN
        SET @pIdSubcontrato = 0;
        SET @pError = '[ALERTA] El número del subcontrato ya existe';
    END
END
