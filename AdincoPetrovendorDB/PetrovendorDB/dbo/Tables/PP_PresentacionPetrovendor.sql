CREATE TABLE [dbo].[PP_PresentacionPetrovendor] (
    [IdPresentacionPetrovendor] INT  IDENTITY (1, 1) NOT NULL,
    [IdUsuario]                 INT  NULL,
    [Visto]                     INT  NULL,
    [VerMasTarde]               BIT  NULL,
    [FechaVisto]                DATE NULL,
    CONSTRAINT [PK_PP_PresentacionPetrovendor] PRIMARY KEY CLUSTERED ([IdPresentacionPetrovendor] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

