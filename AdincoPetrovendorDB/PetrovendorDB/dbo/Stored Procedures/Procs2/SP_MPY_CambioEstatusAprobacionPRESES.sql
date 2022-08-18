CREATE PROCEDURE [dbo].[SP_MPY_CambioEstatusAprobacionPRESES]
    -- Add the parameters for the stored procedure here
    @IdPRESES INT,
    @IdEstatus INT,
    @IdUsuario INT,
    @Justificacion NVARCHAR(MAX)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    declare @matDocGR varchar(20),
            @ReferenceNumber varchar(20),
            @GRNumber varchar(20),
            @PO varchar(100),
            @IdEstatusSAP INT

    --use adinco
    select @ReferenceNumber = SAPSESNumber,
           @GRNumber = MatDocN,
           @PO = SAPPONumber,
           @IdEstatusSAP = IdEstatus
    from adinco..CO_SAPPRESES
    where IdPreses = @IdPRESES



    --Verificar si la proforma está aprobada
    IF EXISTS
    (
        SELECT 1
        FROM Adinco..CO_SAPSES
        WHERE PO_SAPNumer = RTRIM(LTRIM(@PO))
              AND SESReferenceNumber = RTRIM(LTRIM(@ReferenceNumber))
    )
       OR EXISTS
    (
        SELECT 1
        FROM Adinco..CO_SAPGR
        WHERE PO_SAPNumber = RTRIM(LTRIM(@PO))
              AND GRReferenceNumber = RTRIM(LTRIM(@ReferenceNumber))
    )
    BEGIN



        -- Insert statements for procedure here
        UPDATE Adinco.dbo.CO_SAPPRESES
        SET IdEstatus = @IdEstatus,
            Justificacion = @Justificacion,
            ModificadoPor = @IdUsuario,
            ModificadoEl = GETDATE(),
            MatDocN = CASE
                          WHEN ISNULL(MatDocN, '') = '' THEN
                              MatDocN
                          ELSE
                              @GRNumber
                      END
        FROM Adinco.dbo.CO_SAPPRESES PRO
        WHERE IdPRESES = @IdPRESES

        SELECT 'SUCCESS'

        --use adinco
        select @ReferenceNumber = SAPPONumber,
               @GRNumber = MatDocN
        from adinco..CO_SAPPRESES
        where IdPreses = @IdPRESES

        exec adinco..p_MPY_CO_SAPPRESES_Bitacora_Ins @ReferenceNumber,
                                                     @GRNumber,
                                                     @IdUsuario,
                                                     @IdPreses,
                                                     @IdEstatus,
                                                     @Justificacion

    END
    ELSE
    BEGIN
        -- SI ESTA EN APROBACION Y ES UN RECHAZO EL CAMBIO DE ESTATUS
        IF (@IdEstatusSAP = 1 AND @IdEstatus = 3)
        BEGIN
            UPDATE Adinco.dbo.CO_SAPPRESES
            SET IdEstatus = @IdEstatus,
                Justificacion = @Justificacion,
                ModificadoPor = @IdUsuario,
                ModificadoEl = GETDATE()
            FROM Adinco.dbo.CO_SAPPRESES PRO
            WHERE IdPRESES = @IdPRESES

            SELECT 'SUCCESS'

            exec adinco..p_MPY_CO_SAPPRESES_Bitacora_Ins @ReferenceNumber,
                                                         @GRNumber,
                                                         @IdUsuario,
                                                         @IdPreses,
                                                         @IdEstatus,
                                                         @Justificacion
        END
    END

END



