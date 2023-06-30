CREATE TABLE [dbo].[PR_VolumenMensualProduccionPetroleo] (
    [IdReporteVolumenesProduccionPetroleo]      INT             IDENTITY (10000, 1) NOT NULL,
    [IdContrato]                                INT             NULL,
    [MesReporte]                                DATE            NULL,
    [VolumenPetroleoPuntoMedicion]              FLOAT (53)      NULL,
    [GradosAPI]                                 FLOAT (53)      NULL,
    [ContenidoAzufre]                           FLOAT (53)      NULL,
    [VolumenPetroleoAutoconsumo]                FLOAT (53)      NULL,
    [MetanoC1]                                  FLOAT (53)      NULL,
    [EtanoC2]                                   FLOAT (53)      NULL,
    [PropanoC3]                                 FLOAT (53)      NULL,
    [ButanoC4]                                  FLOAT (53)      NULL,
    [MetanoC1Autoconsumo]                       FLOAT (53)      NULL,
    [EtanoC2Autoconsumo]                        FLOAT (53)      NULL,
    [PropanoC3Autoconsumo]                      FLOAT (53)      NULL,
    [ButanoC4Autoconsumo]                       FLOAT (53)      NULL,
    [VolumenCondensadoPuntoMedicion]            FLOAT (53)      NULL,
    [VolumenCondensadoAutoconsumo]              FLOAT (53)      NULL,
    [Bit_CasoFortuito]                          BIT             NULL,
    [CantDiasCasoFortuito]                      INT             NULL,
    [OtrosIngresosUsoCompartidoInfraestructura] DECIMAL (16, 4) NULL,
    [VolumenPetroleoContratistaReparticion]     FLOAT (53)      NULL,
    [VolumenMetanoC1ContratistaReparticion]     FLOAT (53)      NULL,
    [VolumenEtanoC2ContratistaReparticion]      FLOAT (53)      NULL,
    [VolumenPropanoC3ContratistaReparticion]    FLOAT (53)      NULL,
    [VolumenButanoC4ContratistaReparticion]     FLOAT (53)      NULL,
    [VolumenCondensadosContratistaReparticion]  FLOAT (53)      NULL,
    [VolumenPetroleoEstadoReparticion]          FLOAT (53)      NULL,
    [VolumenMetanoC1EstadoReparticion]          FLOAT (53)      NULL,
    [VolumenEtanoC2EstadoReparticion]           FLOAT (53)      NULL,
    [VolumenPropanoC3EstadoReparticion]         FLOAT (53)      NULL,
    [VolumenButanoC4EstadoReparticion]          FLOAT (53)      NULL,
    [VolumenCondensadosEstadoReparticion]       FLOAT (53)      NULL,
    [VolumenPetroleoContratistaCompensacion]    FLOAT (53)      NULL,
    [VolumenMetanoC1ContratistaCompensacion]    FLOAT (53)      NULL,
    [VolumenEtanoC2ContratistaCompensacion]     FLOAT (53)      NULL,
    [VolumenPropanoC3ContratistaCompensacion]   FLOAT (53)      NULL,
    [VolumenButanoC4ContratistaCompensacion]    FLOAT (53)      NULL,
    [VolumenCondensadosContratistaCompensacion] FLOAT (53)      NULL,
    [VolumenPetroleoEstadoCompensacion]         FLOAT (53)      NULL,
    [VolumenMetanoC1EstadoCompensacion]         FLOAT (53)      NULL,
    [VolumenEtanoC2EstadoCompensacion]          FLOAT (53)      NULL,
    [VolumenPropanoC3EstadoCompensacion]        FLOAT (53)      NULL,
    [VolumenButanoC4EstadoCompensacion]         FLOAT (53)      NULL,
    [VolumenCondensadosEstadoCompensacion]      FLOAT (53)      NULL,
    [AcumuladoCostosRecuperablesInsolutos]      MONEY           NULL,
    [VolumenCondensablePuntoMedicion]           FLOAT (53)      NULL,
    [VolumenCondensableAutoconsumo]             FLOAT (53)      NULL,
    [IsEditado]                                 BIT             DEFAULT ((1)) NOT NULL,
    [CreadoPor]                                 INT             NULL,
    [CreadoEl]                                  DATETIME        NULL,
    [ModificadoPor]                             INT             NULL,
    [ModificadoEl]                              DATETIME        NULL,
    [Activo] BIT NULL,
    CONSTRAINT [PK_PR_VolumenMensualProduccion] PRIMARY KEY CLUSTERED ([IdReporteVolumenesProduccionPetroleo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PR_VolumenMensualProduccionPetroleo_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);


GO
-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	
-- =============================================
CREATE TRIGGER dbo.Trigger_VolmenProdPetroleo 
   ON  dbo.PR_VolumenMensualProduccionPetroleo 
   AFTER INSERT,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @mesreporte date


	declare @id  as int 

	select @mesreporte = mesreporte from inserted

	select @id = IdReporteVolumenesProduccionPetroleo   from inserted


	update PR_VolumenMensualProduccionPetroleo set mesreporte  =   datefromparts (year(mesreporte) , month (mesreporte) , 1)   where IdReporteVolumenesProduccionPetroleo = @id 


    -- Insert statements for trigger here

END
