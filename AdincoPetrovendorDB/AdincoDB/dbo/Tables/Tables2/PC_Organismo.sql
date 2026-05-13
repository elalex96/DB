CREATE TABLE [dbo].[PC_Organismo] (
    [IdOrganismo]                    INT            IDENTITY (10000, 1) NOT NULL,
    [OrganismoSecundario]            NVARCHAR (15)  NULL,
    [DescripcionOrganismoSecundario] NVARCHAR (MAX) NULL,
    [CreadoPor]                      INT            NULL,
    [CreadoEn]                       DATETIME       NULL,
    CONSTRAINT [PK_PC_Organismo] PRIMARY KEY CLUSTERED ([IdOrganismo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

